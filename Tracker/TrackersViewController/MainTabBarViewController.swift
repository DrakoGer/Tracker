//
//  MainTabBarViewController.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//


import UIKit

final class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        print("MainTabBarViewController: viewDidLoad called")
        super.viewDidLoad()
        configureTabs()
        styleTabBar()
    }

    private func configureTabs() {
        let journeyVC = TrackersViewController()
        let journeyNav = UINavigationController(rootViewController: journeyVC)
        journeyNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackerIconGrey")?.withRenderingMode(
                .alwaysOriginal),
            selectedImage: UIImage(named: "trackerIconBlue")?.withRenderingMode(
                .alwaysOriginal)
        )

        let statsVC = StatsController()
        let statsNav = UINavigationController(rootViewController: statsVC)
        statsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statisticIconGrey")?.withRenderingMode(
                .alwaysOriginal),
            selectedImage: UIImage(named: "statisticIconBlue")?.withRenderingMode(
                .alwaysOriginal)
        )

        viewControllers = [journeyNav, statsNav]
        selectedIndex = 0
    }

    private func styleTabBar() {
        tabBar.tintColor = UIColor(named: "CustomBlue")
        tabBar.unselectedItemTintColor = UIColor(named: "CustomGray")
        tabBar.backgroundColor = UIColor(named: "CustomWhite")
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor(named: "CustomGray")?.cgColor
    }
}
