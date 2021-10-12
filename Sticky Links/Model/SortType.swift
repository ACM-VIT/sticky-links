//
//  SortType.swift
//  Sticky Links
//
//  Created by Igor Chernyshov on 12.10.2021.
//

/// Supported types of items sorting.
enum SortType: String {

	/// Do not sort items.
	case `none`

	/// Sort items by name.
	case name

	/// Sort items by date created.
	case dateCreated
}
