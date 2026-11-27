/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.smeinvoice.usermanagement.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

/**
 *
 * @author Harmony
 */
@Entity
@Table(name = "investor_profiles")
public class InvestorProfile extends BaseEntity{
    
    @OneToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true, updatable = false)
    private User user;

    @Column(name = "full_name", nullable = false, length = 150)
    private String fullName;

    @Enumerated(EnumType.STRING)
    @Column(name = "investor_type", nullable = false, length = 20)
    private InvestorType investorType;

    @Column(name = "organisation_name", length = 200)
    private String organisationName;

    @Column(nullable = false, length = 30)
    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(name = "risk_appetite", nullable = false, length = 10)
    private RiskAppetite riskAppetite = RiskAppetite.MEDIUM;

    @Enumerated(EnumType.STRING)
    @Column(name = "verification_status", nullable = false, length = 20)
    private VerificationStatus verificationStatus = VerificationStatus.UNVERIFIED;

    protected InvestorProfile() { }

    public InvestorProfile(User user, String fullName, InvestorType investorType, String phone) {
        this.user = user;
        this.fullName = fullName;
        this.investorType = investorType;
        this.phone = phone;
    }

    public User getUser() { return user; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public InvestorType getInvestorType() { return investorType; }
    public void setInvestorType(InvestorType investorType) { this.investorType = investorType; }
    public String getOrganisationName() { return organisationName; }
    public void setOrganisationName(String organisationName) { this.organisationName = organisationName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public RiskAppetite getRiskAppetite() { return riskAppetite; }
    public void setRiskAppetite(RiskAppetite riskAppetite) { this.riskAppetite = riskAppetite; }
    public VerificationStatus getVerificationStatus() { return verificationStatus; }
    public void setVerificationStatus(VerificationStatus verificationStatus) { this.verificationStatus = verificationStatus; }

}
