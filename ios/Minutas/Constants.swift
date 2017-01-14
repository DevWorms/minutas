//
//  Constants.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 07/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation

enum ApplicationConstants{
    static let tiempoParaConsultarServicioWeb = 5.0
    static let ritmoNotificaciones = "ritmoNotificaciones"
    
}

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
    static let closePendiente = "pendientes/close"
    static let reabrirPend = "pendientes/reabrir"
    
    static let pendientes = "pendientes/all/"
    static let tareas = "tasks/"
    static let reportesMe = "reportes/me"
    
    static let asuntos = "tasks/reunion/"
    static let calendarioSemanal = "calendar/week/"
    static let calendarioMensual = "calendar/month/"
    static let asuntoNuevo = "tasks/new"
    
    static let reuniones = "meetings/"
    static let conversaciones = "conversations/"
    static let conversacion = "conversations"
    static let conversacionAddUser = "conversations/addUsers"
    
    static let pendientecomments = "pendientes/comments/"
    static let mensajes = "/messages"
    static let newPendienteReunion = "meetings/pendiente/new"
    
    static let notificaciones = "notifications/full/"
    static let notificacionesLeidas = "notifications/taken"
    
    static let favoritos = "favoritos"
    static let buscador = "search"
    static let buscadorTodo = "search/all"
    
}

enum WebServiceRequestParameter {
    
    static let userIdmin = "user_id"
    static let apiKeymin = "api_key"
    static let busqueda = "q"
    
    static let token = "tokenID"
    static let redSocial = "redSocial"
    static let mensaje = "mensaje"
    static let name = "nombre"
    static let texto = "text"
    static let phone = "telefono"
    static let email = "correo"
    static let username = "apodo"
    static let password = "contrasena"
    static let fileClose = "file[]"
    static let userId = "Id_Usuario"
    static let apiKey = "API_Key"
    static let categoryName = "Nombre_Categoria"
    static let fecha1 = "fecha1"
    static let fecha2 = "fecha2"
    
    static let categoryId = "id_Categoria"
    static let pendienteName = "Nombre_Pendiente"
    static let descripcion = "descripcion"
    static let usuariosAsignados = "Usuarios_Asignados"
    static let usuarios = "Usuarios"
    static let users = "usuarios"
    static let titulo = "Titulo"
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
    static let conversacionId = "conversation_id"
    
    static let apiKeyFavoritos = "api_key"
    static let userIdFavoritos = "user_id"
    static let idFavoritos = "favorito_id"
    static let paramBuscar = "q"
    
    static let notificaciones = "notificaciones"
    
    
    

}

enum WebServiceResponseKey {
    
    static let token = "tokenId"
    static let redSocial = "redSocial"
    static let apiKey = "APIkey"
    static let userId = "Id_Usuario"
    static let id = "id"
    static let nombre = "nombre"
    static let numeroPendientes = "no_pendientes"
    static let resultados = "resultados"
    static let subPendienteId = "id_sub_pendiente"
    
    static let status = "estado"
    static let statusPendiente = "status"
    static let message = "mensaje"
    static let responsable = "responsable"
    static let diasAtraso = "dias_atraso"
    static let indice = "indice"
    
    static let categoryIdMin = "id_categoria"
    static let categoryId = "id_Categoria"
    static let cUserId = "id_usuario"
    static let categoryName = "nombre_categoria"
    static let created = "created_at"
    static let updated = "updated_at"
    static let categories = "categorias"
    static let categoria = "categoria"
    static let usuarios = "users"
    static let user = "user"
    static let apodo = "apodo"
    
    static let pendientes = "pendientes"
    static let notificaciones = "notificaciones"
    
    static let mensajes = "messages"
    static let prioridad = "prioridad"
    static let pendienteId = "id_pendiente"
    static let reunionId = "Id_Reunion"
    
    static let conversacionId = "id_conversation"
    static let elaborado = "updated"
    static let texto = "text"
    
    static let reunionIdCategoria = "id_reunion"
    static let nombrePendiente = "Nombre_Pendiente"
    static let notificacionText = "Texto_Notificacion"
    static let notificacionId = "Id_Notificacion"
    static let notificacionLeida = "Leido_Notificacion"
    
    
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
    static let favoritosList = "fav_users"
    static let nombreFavorito = "nombre"
   
    static let buscarResult = "resultados"
    static let buscarResultUser = "Usuario"
    
    
}

enum HttpStatusCode {
    static let OK = 200
    static let BadRequest = 400
    static let InternalServerError = 500
}
