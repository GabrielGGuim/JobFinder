import ReduxCore
import NetworkLayer

public typealias VacancyListStore = Store<VacancyListState, VacancyListAction>

public extension VacancyListStore {

    /// Cria a Store já configurada com reducer + middleware.
    /// Aceita um `apiClient` injetado pra permitir testes com mock.
    /// Em produção, usa `APIClient.shared` (default).
    static func make(
        apiClient: APIClientProtocol = APIClient.shared
    ) -> VacancyListStore {
        VacancyListStore(
            initialState: VacancyListState(),
            reducer: vacancyListReducer,
            middleware: makeVacancyListMiddleware(apiClient: apiClient)
        )
    }
}
