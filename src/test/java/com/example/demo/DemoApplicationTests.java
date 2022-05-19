package com.example.demo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class DemoApplicationTests {

	void test() {
		var test = "hello world";
		System.out.println("");
	}

	@Test
	void contextLoads() {
		test();
		System.out.print("somethig");
	}

}
