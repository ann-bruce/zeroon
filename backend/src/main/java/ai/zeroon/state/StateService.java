package ai.zeroon.state;

import ai.zeroon.state.StateDtos.StateSnapshot;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserState;
import jakarta.persistence.EntityNotFoundException;
import java.time.Duration;
import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class StateService {

    private static final Duration SHORT_SESSION_WINDOW = Duration.ofSeconds(30);

    private final UserRepository userRepository;
    private final StateHistoryRepository stateHistoryRepository;
    private final StateSessionRepository stateSessionRepository;

    public StateService(
            UserRepository userRepository,
            StateHistoryRepository stateHistoryRepository,
            StateSessionRepository stateSessionRepository) {
        this.userRepository = userRepository;
        this.stateHistoryRepository = stateHistoryRepository;
        this.stateSessionRepository = stateSessionRepository;
    }

    @Transactional(readOnly = true)
    public StateSnapshot getCurrentState(Long userId) {
        UserEntity user = findUser(userId);
        return stateSessionRepository.findFirstByUserIdAndEndedAtIsNull(userId)
                .map(this::toSnapshot)
                .orElseGet(() -> stateHistoryRepository.findFirstByUserIdOrderByCreatedAtDesc(userId)
                        .map(history -> new StateSnapshot(
                                history.getCurrentState(),
                                history.getSource(),
                                history.getCreatedAt(),
                                null,
                                null,
                                0))
                        .orElseGet(() -> new StateSnapshot(
                                user.getCurrentState(),
                                StateSource.SYSTEM,
                                Instant.now(),
                                null,
                                null,
                                0)));
    }

    @Transactional
    public StateSnapshot changeState(Long userId, UserState nextState) {
        return startSession(userId, nextState);
    }

    @Transactional
    public StateSnapshot startSession(Long userId, UserState nextState) {
        if (nextState == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "state is required");
        }
        UserEntity user = findUser(userId);
        Instant now = Instant.now();
        var active = stateSessionRepository.findFirstByUserIdAndEndedAtIsNull(userId);
        if (active.isPresent()) {
            StateSessionEntity session = active.get();
            if (session.getState() == nextState) {
                return toSnapshot(session);
            }
            if (isShortUnrecordedSession(session, now)) {
                stateSessionRepository.delete(session);
                stateSessionRepository.flush();
            } else {
                session.end(now, null);
                stateSessionRepository.flush();
            }
        }
        UserState previousState = user.getCurrentState();
        user.changeState(nextState);
        StateHistoryEntity history = stateHistoryRepository.save(new StateHistoryEntity(
                user,
                previousState,
                nextState,
                StateSource.MANUAL));
        StateSessionEntity session = stateSessionRepository.save(new StateSessionEntity(
                user,
                nextState,
                StateSource.MANUAL,
                history.getCreatedAt()));
        return toSnapshot(session);
    }

    @Transactional(readOnly = true)
    public StateSessionEntity requireActiveSession(Long userId) {
        return stateSessionRepository.findFirstByUserIdAndEndedAtIsNull(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.CONFLICT,
                        "Choose a current state before saving a zero record"));
    }

    @Transactional
    public void endSessionWithRecord(StateSessionEntity session, Long recordId) {
        session.end(Instant.now(), recordId);
    }

    private UserEntity findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
    }

    private StateSnapshot toSnapshot(StateSessionEntity session) {
        return new StateSnapshot(
                session.getState(),
                session.getSource(),
                session.getStartedAt(),
                session.getId(),
                session.getStartedAt(),
                Math.max(0, Duration.between(session.getStartedAt(), Instant.now()).toSeconds()));
    }

    private boolean isShortUnrecordedSession(StateSessionEntity session, Instant now) {
        return session.getEndedByRecordId() == null
                && Duration.between(session.getStartedAt(), now).compareTo(SHORT_SESSION_WINDOW) < 0;
    }
}
