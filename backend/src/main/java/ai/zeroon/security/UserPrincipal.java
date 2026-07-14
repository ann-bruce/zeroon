package ai.zeroon.security;

import ai.zeroon.user.UserRole;
import java.util.Set;

public record UserPrincipal(Long userId, String uid, Set<UserRole> roles) {

    public UserPrincipal {
        roles = Set.copyOf(roles);
    }
}
