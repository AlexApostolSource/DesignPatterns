//
//  Kata1Factory.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//
import NetworkLayer
import UIKit

protocol Kata1FactoryMethodProtocol {
    static func createKata1() -> UIViewController
}

struct Kata1FactoryMethod: Kata1FactoryMethodProtocol {
    static func createKata1() -> UIViewController {
        NetworkLayerConfig.config(host: "jsonplaceholder.typicode.com")
        let requestProvider: RequestProviderProtocol = RequestProvider.basic
        let remoteDataSource = Kata1RemoteDataSource(
            requestProvider: requestProvider
        )
        let localDataSource = Kata1LocalDataSource(
            fileManager: FileManager.default
        )

        let kata1Repository = Kata1Repository(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource
        )

        let kata1UseCase = Kata1GetPostsUseCaseOperaration(
            repository: kata1Repository,
            mapper: Kata1GetPostsUseCaseOperarationMapper()
        )

        let kata1Facade = PostsServiceFacade(
            useCase: kata1UseCase,
            analytics: Kata1AnalyticsStdout()
        )

        let viewModel = Kata1ViewModel(facade: kata1Facade)

       
        return MassivePostsViewController(viewModel: viewModel)
    }
}

extension FileManager: Kata1LocalDataSourceFileManagerProtocol {}
