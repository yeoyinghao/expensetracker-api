package com.portfolio.expensetracker.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class FirstEndpoint {

    @GetMapping("/")
    public String hello(){
        return "Hello, test world!";
    }

    @GetMapping("/create")
    public String create(){
        return "Create an Expense";
    }
    
}
