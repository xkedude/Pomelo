//
//  MissingFilesController.swift
//  Folium
//
//  Created by Jarrod Norwell on 8/3/2024.
//

import Foundation
import UIKit

class MissingFilesController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<String, MissingFile>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, MissingFile>! = nil
    
    var core: Core
    init(core: Core, collectionViewLayout: UICollectionViewLayout) {
        self.core = core
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        title = "Missing Files"
        view.backgroundColor = .systemBackground
        
        let missingFileCellRegistration = UICollectionView.CellRegistration<MissingFileCell, MissingFile> { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier)
        }
        
        let supplementaryViewRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            
            contentConfiguration.text = self.dataSource.sectionIdentifier(for: indexPath.section) ?? ""
            contentConfiguration.textProperties.color = .label
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: missingFileCellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKimd, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryViewRegistration, for: indexPath)
        }
        
        snapshot = .init()
        let sectionIdentifiers = core.missingFiles.reduce(into: [String](), { partialResult, element in
            if !partialResult.contains(element.fileImportance.description) {
                partialResult.append(element.fileImportance.description)
            }
        }).sorted()
        
        snapshot.appendSections(sectionIdentifiers)
        sectionIdentifiers.forEach { sectionIdentifier in
            snapshot.appendItems(core.missingFiles.filter { $0.fileImportance.description == sectionIdentifier }, toSection: sectionIdentifier)
        }
        
        Task {
            await dataSource.apply(snapshot)
        }
    }
}
