//
//  Constants.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 07/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation

enum WebServiceEndpoint {
    static let baseUrl = "https://dev.minute.mx/api/"
    
    static let signup = "user/register"
    static let login = "user/login/"
    static let socialLogin = ""
    static let recoverPassword = "user/recoverpassword/"
    static let resetPassword = ""
    
    static let categories = "category/all/"
    static let newCategory = "category/new"
}

enum WebServiceRequestParameter {
    static let name = "nombre"
    static let phone = "telefono"
    static let email = "correo"
    static let username = "apodo"
    static let password = "contrasena"
    
    static let userId = "Id_Usuario"
    static let apiKey = "API_Key"
    static let categoryName = "Nombre_Categoria"
}

enum WebServiceResponseKey {
    static let apiKey = "APIkey"
    static let userId = "Id_Usuario"
    static let status = "estado"
    static let message = "mensaje"
    
    static let categoryId = "id_Categoria"
    static let cUserId = "id_usuario"
    static let categoryName = "nombre_categoria"
    static let created = "created_at"
    static let updated = "updated_at"
    static let categories = "categorias"
}

enum HttpStatusCode {
    static let OK = 200
    static let BadRequest = 400
    static let InternalServerError = 500
}
