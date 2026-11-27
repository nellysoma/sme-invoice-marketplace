/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.smeinvoice.usermanagement;

/**
 *
 * @author Harmony
 */

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.smeinvoice.common.Role;
import com.smeinvoice.usermanagement.model.InvestorProfile;
import com.smeinvoice.usermanagement.model.InvestorType;
import com.smeinvoice.usermanagement.model.SmeProfile;
import com.smeinvoice.usermanagement.model.User;
import com.smeinvoice.usermanagement.model.UserStatus;
import com.smeinvoice.usermanagement.repository.InvestorProfileRepository;
import com.smeinvoice.usermanagement.repository.SmeProfileRepository;
import com.smeinvoice.usermanagement.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.test.context.ActiveProfiles;

/** Runs against the local PostgreSQL database user_test_db (set DB_PASSWORD). */
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("test")
public class UserRepositoryTest {
    
    private static final String FAKE_HASH = "$2a$10$abcdefghijklmnopqrstuuabcdefghijklmnopqrstuvwxyz0123";

    @Autowired UserRepository users;
    @Autowired SmeProfileRepository smeProfiles;
    @Autowired InvestorProfileRepository investorProfiles;

    @Test
    void savesUserWithDefaultsAndFindsByEmailIgnoringCase() {
        User saved = users.saveAndFlush(new User("  Ada@Example.com ", FAKE_HASH, Role.SME));

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getCreatedAt()).isNotNull();
        assertThat(saved.getStatus()).isEqualTo(UserStatus.PENDING_VERIFICATION);
        assertThat(users.findByEmailIgnoreCase("ADA@example.COM")).isPresent();
        assertThat(users.existsByEmailIgnoreCase("nobody@example.com")).isFalse();
    }

    @Test
    void rejectsDuplicateEmailDifferingOnlyByCase() {
        users.saveAndFlush(new User("dup@example.com", FAKE_HASH, Role.INVESTOR));

        assertThatThrownBy(() -> users.saveAndFlush(new User("DUP@example.com", FAKE_HASH, Role.INVESTOR)))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void linksSmeProfileToUserAndRejectsDuplicateRegistrationNumber() {
        User u1 = users.save(new User("sme1@example.com", FAKE_HASH, Role.SME));
        User u2 = users.save(new User("sme2@example.com", FAKE_HASH, Role.SME));
        smeProfiles.saveAndFlush(new SmeProfile(u1, "Acme Ltd", "RC123456", "Ada Obi", "08012345678"));

        assertThat(smeProfiles.findByUserId(u1.getId())).isPresent();
        assertThat(smeProfiles.existsByRegistrationNumber("RC123456")).isTrue();

        assertThatThrownBy(() -> smeProfiles.saveAndFlush(
                new SmeProfile(u2, "Other Ltd", "RC123456", "Bo Eze", "08099999999")))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void linksInvestorProfileToUser() {
        User u = users.save(new User("inv@example.com", FAKE_HASH, Role.INVESTOR));
        investorProfiles.saveAndFlush(new InvestorProfile(u, "Chidi Okeke", InvestorType.INDIVIDUAL, "08011112222"));

        assertThat(investorProfiles.findByUserId(u.getId())).isPresent();
    }
}
