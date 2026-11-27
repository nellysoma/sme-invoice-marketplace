/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.smeinvoice.usermanagement.repository;

import com.smeinvoice.usermanagement.model.InvestorProfile;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 *
 * @author Harmony
 */
public interface InvestorProfileRepository extends JpaRepository<InvestorProfile, UUID>{
    
    Optional<InvestorProfile> findByUserId(UUID userId);
}
