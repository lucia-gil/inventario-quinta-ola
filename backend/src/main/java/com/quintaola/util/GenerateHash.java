package com.quintaola.util;

import org.mindrot.jbcrypt.BCrypt;

public class GenerateHash {
    public static void main(String[] args) {
        String[] passwords = {"admin123", "lucia123"};
        for (String pwd : passwords) {
            System.out.println(pwd + " → " + BCrypt.hashpw(pwd, BCrypt.gensalt()));
        }
    }
}