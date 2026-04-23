package com.portfolio.expensetracker.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.portfolio.expensetracker.entity.Expense;
import com.portfolio.expensetracker.service.TrackerService;

@RestController
public class ExpenseController {

    private final TrackerService service;

    public ExpenseController(TrackerService service) {
        this.service = service;
    }

    @GetMapping("/")
    public String hello(){
        return "Start tracking with your expense with /create!";
    }

    @PostMapping("/create")
    public Expense create(@RequestBody Expense expense){
        return service.save(expense);
    }

    @GetMapping("/expense/{id}")
    public Expense find(@PathVariable Long id) {
        return service.findById(id);
    }
    
    @GetMapping("/expense")
    public List<Expense> findAll() {
        return service.findAll();
    }

    @DeleteMapping("/expense/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.deleteById(id);
    }
}
