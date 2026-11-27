/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.smeinvoice.usermanagement.repository;

import com.smeinvoice.usermanagement.model.SmeProfile;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 *
 * @author Harmony
 */
public interface SmeProfileRepository extends JpaRepository<SmeProfile, UUID> {
    
    Optional<SmeProfile> findByUserId(UUID userId);

    boolean existsByRegistrationNumber(String registrationNumber);
}
