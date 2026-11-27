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
@Table(name = "sme_profiles")
public class SmeProfile extends BaseEntity{
    
    @OneToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true, updatable = false)
    private User user;

    @Column(name = "business_name", nullable = false, length = 200)
    private String businessName;

    @Column(name = "registration_number", nullable = false, unique = true, length = 50)
    private String registrationNumber;

    @Column(name = "tax_id", length = 50)
    private String taxId;

    @Column(length = 100)
    private String industry;

    @Column(name = "business_address", length = 300)
    private String businessAddress;

    @Column(length = 100)
    private String city;

    @Column(length = 100)
    private String state;

    @Column(name = "contact_person", nullable = false, length = 150)
    private String contactPerson;

    @Column(nullable = false, length = 30)
    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(name = "verification_status", nullable = false, length = 20)
    private VerificationStatus verificationStatus = VerificationStatus.UNVERIFIED;

    protected SmeProfile() { }

    public SmeProfile(User user, String businessName, String registrationNumber,
                      String contactPerson, String phone) {
        this.user = user;
        this.businessName = businessName;
        this.registrationNumber = registrationNumber;
        this.contactPerson = contactPerson;
        this.phone = phone;
    }

    public User getUser() { return user; }
    public String getBusinessName() { return businessName; }
    public void setBusinessName(String businessName) { this.businessName = businessName; }
    public String getRegistrationNumber() { return registrationNumber; }
    public void setRegistrationNumber(String registrationNumber) { this.registrationNumber = registrationNumber; }
    public String getTaxId() { return taxId; }
    public void setTaxId(String taxId) { this.taxId = taxId; }
    public String getIndustry() { return industry; }
    public void setIndustry(String industry) { this.industry = industry; }
    public String getBusinessAddress() { return businessAddress; }
    public void setBusinessAddress(String businessAddress) { this.businessAddress = businessAddress; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public String getContactPerson() { return contactPerson; }
    public void setContactPerson(String contactPerson) { this.contactPerson = contactPerson; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public VerificationStatus getVerificationStatus() { return verificationStatus; }
    public void setVerificationStatus(VerificationStatus verificationStatus) { this.verificationStatus = verificationStatus; }
}
