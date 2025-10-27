package com.enmer.proyect2.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SignupRequest (@NotBlank @Size(min = 3) String nombre, @NotBlank @Email String email, @NotBlank @Size(min = 6) String password)  {
}
