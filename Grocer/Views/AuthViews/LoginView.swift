//
//  LoginView.swift
//  Grocer
//
//  Created by Emil on 7/6/26.
//

import SwiftUI

struct LayoutConfig {
    let offsetX: CGFloat
    let offsetY: CGFloat
    let fontSize: CGFloat
    let contentMode: ContentMode
    let alignment: Alignment
    let scale: CGFloat
    let visibility: Color
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var successLogin: Bool = false

    var layout: LayoutConfig {
        if successLogin {
            return LayoutConfig(
                offsetX: 0,
                offsetY: 0,
                fontSize: 0,
                contentMode: .fit,
                alignment: .center,
                scale: 5,
                visibility: .clear
            )
        } else {
            return LayoutConfig(
                offsetX: -190,
                offsetY: -260,
                fontSize: 40,
                contentMode: .fill,
                alignment: .topLeading,
                scale: 1,
                visibility: .primary
            )
        }
    }
    var body: some View {
        VStack {
            Spacer()
            Text("Grocer")
                .font(.system(size: layout.fontSize))
                .bold()
                .foregroundStyle(layout.visibility)

            Spacer()
            if !successLogin {
                TextField("Email", text: $email)
                    .autocorrectionDisabled()
                    .padding()
                    .glassEffect(
                        .regular.interactive(),
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    .frame(width: .infinity)

                SecureField("Password", text: $password)
                    .autocorrectionDisabled()
                    .padding()
                    .glassEffect(
                        .regular.interactive(),
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    .frame(width: .infinity)

                Button {
                    print("Login info submitted")
                    withAnimation(.spring(duration: 1)) {
                        successLogin.toggle()
                    }

                } label: {
                    HStack {
                        Text("Login")
                    }
                    .frame(width: .infinity)
                    .padding([.leading, .trailing], 50)
                }
                .buttonStyle(.glassProminent)
                .frame(alignment: .center)

                Spacer()
            }
        }
        .background(alignment: layout.alignment) {
            Image(systemName: "cart")
                .resizable()
                .aspectRatio(contentMode: layout.contentMode)
                .clipped()
                .offset(x: layout.offsetX, y: layout.offsetY)
                .scaleEffect(layout.scale)
                .onTapGesture {
                    successLogin.toggle()
                }
        }
    }
}

#Preview {
    LoginView().padding()
}
