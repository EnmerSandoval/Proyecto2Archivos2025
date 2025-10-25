package com.enmer.proyect2;

import lombok.RequiredArgsConstructor;
import org.hibernate.boot.model.relational.Database;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;


@Component
@ConditionalOnProperty(name = "app.smoke.enabled", havingValue = "true", matchIfMissing = true)
@RequiredArgsConstructor
public class DbSmokeTest implements ApplicationRunner {
    private final JdbcTemplate jdbc;

    @Override
    public void run(org.springframework.boot.ApplicationArguments args) {
        Integer one = jdbc.queryForObject("select 1", Integer.class);
        System.out.println("DB smoke OK => " + one);
    }
}
