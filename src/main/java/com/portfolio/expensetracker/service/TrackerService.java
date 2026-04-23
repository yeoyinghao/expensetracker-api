package com.portfolio.expensetracker.service;

import java.util.List;

import com.portfolio.expensetracker.entity.Expense;
import com.portfolio.expensetracker.repository.ExpenseRepository;

public class TrackerService {
    private final ExpenseRepository expenseRepository;

    public TrackerService(ExpenseRepository expenseRepository) {
        this.expenseRepository = expenseRepository;
    }

    public Expense save(Expense expense) {
        return expenseRepository.save(expense);
    }

    public List<Expense> findAll() {
        return expenseRepository.findAll();
    }

    public Expense findById(Long id) {
        return expenseRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Expense not found"));
    }

    public void deleteById(Long id){
        Expense expense = findById(id);
        expenseRepository.delete(expense);
    }
}
