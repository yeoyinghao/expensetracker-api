package com.portfolio.expensetracker.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.portfolio.expensetracker.entity.Expense;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {}
