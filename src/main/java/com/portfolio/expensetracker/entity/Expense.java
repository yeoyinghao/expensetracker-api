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
@Table(schema="public", name="expense")
public class Expense {

    @Id
    @GeneratedValue
    private Long id;

    @Column(name="name", length=50, nullable=false, unique=false)
    private String name;

    @Column(name="amount", nullable=false, unique=false)
    private int amount;

    @Enumerated(EnumType.STRING)
    private ExpenseType expenseType;

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public ExpenseType getExpenseType() {
        return expenseType;
    }

    public void setExpenseType(ExpenseType expenseType) {
        this.expenseType = expenseType;
    }
}
