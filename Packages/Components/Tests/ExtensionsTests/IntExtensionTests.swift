//
//  IntExtensionTests.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 11/07/26.
//


//
//  IntExtensionTests.swift
//  ExtensionsTests
//
//  Cobre: Int.asRelativeTimeString
//  Fonte: Packages/Components/Sources/Extensions/Int+Extension.swift
//
//  NOTA: a função usa Date() e RelativeDateTimeFormatter, então os testes
//  NÃO validam o texto exato (depende de locale/hora atual). Eles garantem
//  que a formatação ocorra e que números apareçam na string. Em Parte 4
//  vamos ver como injetar o relógio pra ter asserts mais fortes.
//

import XCTest
@testable import Extensions

final class IntExtensionTests: XCTestCase {

    func test_asRelativeTimeString_quandoTimestampEmEpochZero_deveRetornarStringNaoVazia() {
        XCTAssertFalse(Int(0).asRelativeTimeString.isEmpty)
    }

    func test_asRelativeTimeString_quandoTimestampPassado_deveConterAoMenosUmDigito() {
        // 1 hora atrás
        let past = Int(Date().timeIntervalSince1970) - 3_600

        let result = past.asRelativeTimeString

        let hasDigit = result.contains(where: { $0.isNumber })
        XCTAssertTrue(hasDigit, "Era esperado conter pelo menos um dígito (o intervalo): '\(result)'")
    }

    func test_asRelativeTimeString_quandoTimestampFuturo_deveRetornarStringNaoVazia() {
        let future = Int(Date().timeIntervalSince1970) + 3_600

        XCTAssertFalse(future.asRelativeTimeString.isEmpty)
    }
}