package ai.zeroon.auth;

import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserRole;
import ai.zeroon.user.UserStatus;
import java.util.UUID;
import org.springframework.security.authentication.DisabledException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminAccountProvisioningService {

    private final UserRepository userRepository;

    public AdminAccountProvisioningService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public UserEntity provision(String email) {
        UserEntity user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            return userRepository.save(UserEntity.createAdmin(createUid(), email));
        }
        if (user.getStatus() != UserStatus.ACTIVE) {
            throw new DisabledException("Admin account is not active");
        }
        user.grantRole(UserRole.ADMIN);
        return user;
    }

    private String createUid() {
        return "a" + UUID.randomUUID().toString().replace("-", "").substring(0, 24);
    }
}
