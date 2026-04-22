package com.portfolio.expensetracker.entity;

import com.portfolio.expensetracker.customenum.ExpenseType;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(schema="default", name="expense")
public class Expense {

    @Id
    @GeneratedValue
    private Long id;

    @Column(name="name", length=50, nullable=false, unique=false)
    private String name;

    @Column(name="amount", length=50, nullable=false, unique=false)
    private int amount;

    @Enumerated(EnumType.STRING)
    private ExpenseType type;
}
