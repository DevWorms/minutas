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
    static let find = "user/find/"
    static let perfil = "user/profile/"
    static let loginWithTw = "user/loginwithttwitter/"
    static let loginWithIn = "user/loginwithlinkedin/"
    static let loginWithFb = "user/loginwithfacebook/"
    
    static let newCategory = "category/new"
    static let newReunion = "meeting/new"
    static let newMinute = "minuta/new"
    
    static let newPendiente = "pendientes/new"
    
    static let pendientes = "pendientes/all/"
    static let tareas = "tasks/"
    static let asuntos = "tasks/reunion/"
    static let calendarioSemanal = "calendar/week/"
    static let calendarioMensual = "calendar/month/"
    static let asuntoNuevo = "tasks/new"
    static let reuniones = "meetings/"
    static let conversaciones = "conversations/"
    static let pendientecomments = "pendientes/comments/"
}

enum WebServiceRequestParameter {
    static let token = "tokenID"
    static let redSocial = "redSocial"
    
    static let name = "nombre"
    static let phone = "telefono"
    static let email = "correo"
    static let username = "apodo"
    static let password = "contrasena"
    
    static let userId = "Id_Usuario"
    static let apiKey = "API_Key"
    static let categoryName = "Nombre_Categoria"
    
    static let categoryId = "id_Categoria"
    static let pendienteName = "Nombre_Pendiente"
    static let descripcion = "descripcion"
    static let usuariosAsignados = "Usuarios_Asignados"
    static let autopostergar = "Auto_Postergar"
    static let autoasignar = "auto_asignar"
    
    static let prioridad = "prioridad"
    static let fechaFin = "Fecha_Fin"
    static let responsable = "responsable"
    static let nombreReunion = "Nombre_Reunion"
    
    static let diaReunion = "Dia_Reunion"
    static let horaReunion = "Hora_Reunion"
    static let lugarReunion = "Lugar_Reunion"
    static let objetivoReunion = "objetivo"
    static let subPendienteId = "id_sub_pendiente"
    static let pendienteId = "id_pendiente"
    static let asuntos = "asuntos[]"
    
    static let reunionId = "id_reunion"
    static let reunionIDq = "Id_Reunion"
    static let nombreSubPendiente = "nombre_sub_pendiente"
    static let obj_Reunion = "Objetivo_Reunion"
    static let acuerdoMinuta = "Acuerdo_Minuta[]"
    static let asunto_Minuta = "Asunto_Minuta"
    

}

enum WebServiceResponseKey {
    
    static let token = "tokenId"
    static let redSocial = "redSocial"
    static let apiKey = "APIkey"
    static let userId = "Id_Usuario"
    static let id = "id"
    
    static let status = "estado"
    static let statusPendiente = "status"
    static let message = "mensaje"
    static let responsable = "responsable"
    
    static let categoryId = "id_Categoria"
    static let cUserId = "id_usuario"
    static let categoryName = "nombre_categoria"
    static let created = "created_at"
    static let updated = "updated_at"
    static let categories = "categorias"
    static let usuarios = "users"
    static let user = "user"
    static let apodo = "apodo"
    
    static let pendientes = "pendientes"
    static let mensajes = "messages"
    static let prioridad = "prioridad"
    static let pendienteId = "id_pendiente"
    static let reunionId = "Id_Reunion"
    
    static let conversacionId = "id_conversation"
    static let elaborado = "updated"
    static let texto = "text"
    
    static let reunionIdCategoria = "id_reunion"
    static let nombrePendiente = "Nombre_Pendiente"
    static let descripcion = "descripcion"
    static let autoPostergar = "Auto_Postergar"
    static let altaPrioridad = "Alta_Prioridad"
    static let fechaInicio = "Fecha_Inicio"
    static let fechaFin = "Fecha_Fin"
    static let fechaCierre = "2016-12-04"
    static let pendienteStatus = "status"
    static let miembros = "members"
    static let miembro = "member"
    
    static let pendienteStatusVisible = "status_visible"
    static let usuariosAsignados = "Usuarios_Asignados"
    static let files = "Usuarios_Asignados"
    static let fileName = "name"
    static let fileUrl = "url"
    static let total = "total"
    static let completados = "completados"
    static let objetivoReunion = "objetivo"
    
    static let nombreSubPendientes = "nombre_sub_pendiente"
    static let nombreReunion = "Nombre_Reunion"
    static let tituloChat = "title"
    static let diaReunion = "Dia_Reunion"
    static let horaReunion = "Hora_Reunion"
    static let participantes = "Usuarios_Asignados"
    static let reuniones = "reuniones"
    static let conversaciones = "conversations"
    
    
}

enum HttpStatusCode {
    static let OK = 200
    static let BadRequest = 400
    static let InternalServerError = 500
}
