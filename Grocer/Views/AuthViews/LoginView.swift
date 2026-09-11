//
//  LoginView.swift
//  Grocer
//
//  Created by Emil on 7/22/26.
//

import SwiftUI

private struct LayoutConfig {
    let offsetX: CGFloat
    let offsetY: CGFloat
    let fontSize: CGFloat
    let contentMode: ContentMode
    let alignment: Alignment
    let scale: CGFloat
    let visibility: Color
}

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    private var authService = AuthService()
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var successLogin: Bool = false
    @State private var isRegistering: Bool = false

    private var layout: LayoutConfig {
        if successLogin {
            return LayoutConfig(
                offsetX: 0,
                offsetY: 50,
                fontSize: 0,
                contentMode: .fit,
                alignment: .bottom,
                scale: 3,
                visibility: .clear
            )
        } else {
            return LayoutConfig(
                offsetX: 0,
                offsetY: -100,
                fontSize: 40,
                contentMode: .fill,
                alignment: .topTrailing,
                scale: 1,
                visibility: .primary
            )
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("Bienvenido de vuelta")
                .font(.system(size: layout.fontSize))
                .bold()
                .foregroundStyle(layout.visibility)

            Spacer()
            if !successLogin {
                VStack {
                    if isRegistering {
                        HStack {
                            Image(systemName: "person.circle")
                            TextField("Nombre", text: $name)
                                .autocorrectionDisabled()
                                .padding()
                                .frame(maxWidth: .infinity)

                        }
                        .padding([.leading])
                    }

                    Divider()
                        .padding([.leading, .trailing])
                    HStack {
                        Image(systemName: "person.text.rectangle")
                        TextField("Usuario", text: $username)
                            .autocorrectionDisabled()
                            .padding()
                            .frame(maxWidth: .infinity)

                    }
                    .padding([.leading])

                    Divider()
                        .padding([.leading, .trailing])

                    HStack {
                        Image(systemName: "key.circle")
                        SecureField("Contraseña", text: $password)
                            .autocorrectionDisabled()
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .padding([.leading])
                }
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: 20)
                )
                if !isRegistering {
                    Button {
                        print("Login info submitted")
                        Task {
                            do {
                                let service = AuthService()
                                let loginResponse = try await service.login(
                                    username: username,
                                    password: password
                                )
                                withAnimation(.spring(duration: 1)) {
                                    successLogin = true
                                }
                                try? await Task.sleep(for: .seconds(1))
                                authManager.login(
                                    with: loginResponse.accessToken,
                                    and: loginResponse.refreshToken
                                )

                            } catch {
                                print("Failed: \(error)")
                            }
                        }

                    } label: {
                        HStack {
                            Text("Iniciar sesión")
                        }
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .padding([.leading, .trailing], 50)
                    }
                    .padding([.top, .bottom], 10)
                    .buttonStyle(.glassProminent)
                    .frame(alignment: .center)

                    HStack {
                        VStack {
                            Divider()
                        }
                        Text("o")
                        VStack {
                            Divider()
                        }
                    }
                    .padding([.leading, .trailing])

                    Button {
                        withAnimation(.spring(duration: 0.5)) {
                            isRegistering.toggle()
                        }
                    } label: {
                        Text("Registrate")
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .padding([.leading, .trailing], 50)
                    }
                    .buttonStyle(.glass)
                    .padding([.top, .bottom], 10)
                    .frame(alignment: .center)

                } else {
                    Button {
                        print("Register submitted")
                        Task {
                            do {
                                let service = AuthService()
                                let registerResponse = try await service.register(
                                    username: username,
                                    password: password,
                                    name: name
                                )
                                authManager.login(
                                    with: registerResponse.accessToken,
                                    and: registerResponse.refreshToken
                                )
                                try? await Task.sleep(for: .seconds(1))
                                withAnimation(.spring(duration: 1)) {
                                    successLogin = true
                                }

                            } catch {
                                print("Failed: \(error)")
                            }
                        }

                    } label: {
                        HStack {
                            Text("Registrar")
                        }
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .padding([.leading, .trailing], 50)
                    }
                    .padding([.top, .bottom], 10)
                    .buttonStyle(.glassProminent)
                    .frame(alignment: .center)

                    HStack {
                        VStack {
                            Divider()
                        }
                        Text("o")
                        VStack {
                            Divider()
                        }
                    }
                    .padding([.leading, .trailing])

                    Button {
                        withAnimation(.spring(duration: 0.5)) {
                            isRegistering.toggle()
                        }
                    } label: {
                        Text("Cancelar")
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .padding([.leading, .trailing], 50)
                    }
                    .buttonStyle(.glass)
                    .padding([.top, .bottom], 10)
                    .frame(alignment: .center)
                }

                Spacer()

                HStack {
                    Spacer()
                    Text(
                        "Al continuar aceptas los términos de servicio y politica de privacidad."
                    )
                    .frame(maxWidth: 250, alignment: .center)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .background(alignment: layout.alignment) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.blue, .black],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .blur(radius: 100)
                .frame(width: 200, height: 200)
                .offset(x: layout.offsetX, y: layout.offsetY)
                .scaleEffect(layout.scale)
        }

    }
}

#Preview {

    LoginView().padding().environment(AuthManager())
}
