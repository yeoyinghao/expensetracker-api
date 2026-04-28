package com.portfolio.expensetracker.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;

import com.portfolio.expensetracker.entity.Expense;
import com.portfolio.expensetracker.repository.ExpenseRepository;

@Service
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

    public void updateById(Long id,@RequestBody Expense expenseDetails){
        Expense updateExpense = expenseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Expense not exist with id: " + id));

        updateExpense.setAmount(expenseDetails.getAmount());

        expenseRepository.save(updateExpense);
    }
}
