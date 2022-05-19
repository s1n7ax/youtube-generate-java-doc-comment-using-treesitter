package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Home {
	String welcomeMsg = "Hello";

	/**
	 * getSomething <description>
	 * @param { String } name <description>
	 * @param { int } test <description>
	 * @returns { String } <description>
	 */
	@GetMapping("/test")
	public String getSomething(String name, int test) {
		return this.welcomeMsg + name;
	}
}
