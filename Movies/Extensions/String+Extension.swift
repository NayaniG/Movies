//
//  String+Extension.swift
//  Movies
//
//  Created by SJI-GOA-79 on 16/12/22.
//

import Foundation

extension String{
    var emailRegEx: String {
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    }
    
    var passwordRegEx: String {
            return "^(?=.*[0-9])(?=.*?[#?!@$%^&<>*~:`-])(?!.* ).{8,16}$"
    }
}
