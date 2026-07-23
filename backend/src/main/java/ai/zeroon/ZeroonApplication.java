package ai.zeroon;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ZeroonApplication {

    public static void main(String[] args) {
        SpringApplication.run(ZeroonApplication.class, args);
    }
}
