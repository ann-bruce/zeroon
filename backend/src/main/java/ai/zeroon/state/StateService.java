package ai.zeroon.state;

import ai.zeroon.state.StateDtos.StateSnapshot;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserState;
import jakarta.persistence.EntityNotFoundException;
import java.time.Instant;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StateService {

    private final UserRepository userRepository;
    private final StateHistoryRepository stateHistoryRepository;

    public StateService(UserRepository userRepository, StateHistoryRepository stateHistoryRepository) {
        this.userRepository = userRepository;
        this.stateHistoryRepository = stateHistoryRepository;
    }

    @Transactional(readOnly = true)
    public StateSnapshot getCurrentState(Long userId) {
        UserEntity user = findUser(userId);
        return stateHistoryRepository.findFirstByUserIdOrderByCreatedAtDesc(userId)
                .map(history -> new StateSnapshot(
                        history.getCurrentState(),
                        history.getSource(),
                        history.getCreatedAt()))
                .orElseGet(() -> new StateSnapshot(user.getCurrentState(), StateSource.SYSTEM, Instant.now()));
    }

    @Transactional
    public StateSnapshot changeState(Long userId, UserState nextState) {
        UserEntity user = findUser(userId);
        UserState previousState = user.getCurrentState();
        user.changeState(nextState);
        StateHistoryEntity history = stateHistoryRepository.save(new StateHistoryEntity(
                user,
                previousState,
                nextState,
                StateSource.MANUAL));
        return new StateSnapshot(history.getCurrentState(), history.getSource(), history.getCreatedAt());
    }

    private UserEntity findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
    }
}
