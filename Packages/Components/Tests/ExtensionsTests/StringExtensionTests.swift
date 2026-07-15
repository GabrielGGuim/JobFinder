//
//  ViewModifiersTests.swift
//  
//
//  Created by Mateus Rodrigues on 02/09/24.
//

import XCTest
@testable import Extensions

final class StringExtensionTests: XCTestCase {

    // MARK: - htmlStripped

    func test_htmlStripped_quandoTemTagsSimples_deveRemoverTags() {
        // Arrange
        let html = "<p>Olá <strong>mundo</strong></p>"

        // Act
        let result = html.htmlStripped

        // Assert
        XCTAssertEqual(result, "Olá mundo")
    }

    func test_htmlStripped_quandoTemEntidadeAmp_deveConverterParaEComercial() {
        XCTAssertEqual("Tom &amp; Jerry".htmlStripped, "Tom & Jerry")
    }

    func test_htmlStripped_quandoTemEntidadeNbsp_deveConverterParaEspaco() {
        XCTAssertEqual("a&nbsp;b".htmlStripped, "a b")
    }

    func test_htmlStripped_quandoTemEntidadeQuot_deveConverterParaAspaDupla() {
        XCTAssertEqual("&quot;teste&quot;".htmlStripped, "\"teste\"")
    }

    func test_htmlStripped_quandoTemEntidadesDiversas_deveAplicarTodasConversoes() {
        let input = "&lt;b&gt;oi&lt;/b&gt; &amp; &quot;ok&quot; &#39;fim&#39;"

        XCTAssertEqual(input.htmlStripped, "<b>oi</b> & \"ok\" 'fim'")
    }

    func test_htmlStripped_quandoTextoSemHTML_devePermanecerIgual() {
        let original = "Texto puro sem tags"

        XCTAssertEqual(original.htmlStripped, original)
    }

    func test_htmlStripped_quandoStringVazia_deveRetornarVazia() {
        XCTAssertEqual("".htmlStripped, "")
    }
}
