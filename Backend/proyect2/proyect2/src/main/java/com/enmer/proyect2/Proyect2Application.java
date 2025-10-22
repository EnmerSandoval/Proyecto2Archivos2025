package com.enmer.proyect2;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.hibernate.autoconfigure.HibernateJpaAutoConfiguration;
import org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration;
import org.springframework.boot.security.autoconfigure.servlet.SecurityAutoConfiguration;

@SpringBootApplication
public class Proyect2Application {

	public static void main(String[] args) {
		SpringApplication.run(Proyect2Application.class, args);
	}

}
