//
//  MealPlanViewController.swift
//  MacroHero
//
//  Created by Nadia Siddiqah on 12/30/21.
//

import UIKit
import Combine
import PKHUD

class MealPlanVC: UIViewController {
    
    // MARK: - PROPERTIES
    private var viewModel: MealPlanVM
    private var cancellables = Set<AnyCancellable>()
    
    var contentViewSize = CGSize(width: Utils.screenWidth,
                                 height: Utils.screenHeight + Utils.screenHeight * 0.11)
    
    var breakfast = MealInfo()
    var lunch = MealInfo()
    var dinner = MealInfo()
    var protein = MealInfo()
    
    var allMeals = MealPlan()
    
    // MARK: - Initializers
    init(viewModel: MealPlanVM) {
        self.viewModel = viewModel
        self.allMeals = viewModel.mealPlan
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - VIEW METHODS
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
//        viewModel.getMealData(reqs: breakfastReq) { _ in
//            self.allMeals.breakfast = self.viewModel.mealPlan.breakfast
//        }
//        viewModel.getMealData(reqs: self.breakfastReq) { _ in
//            print("retrieved")
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        DispatchQueue.main.async {
//            self.viewModel.getMealData(reqs: self.breakfastReq) { [weak self] data in
//                self?.meal = data
//            }
//        }
//
//        print(meal)
    }
    
    // MARK: - VIEW OBJECTS
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.frame = self.view.bounds
        view.contentSize = contentViewSize
        view.autoresizingMask = .flexibleHeight
        view.showsHorizontalScrollIndicator = true
        view.bounces = true
        
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.frame.size = contentViewSize
        
        return view
    }()
    
    lazy var mainTitle: UILabel = {
        let label = Utils.createMainTitle(text: "TODAY'S MEAL PLAN",
                                          width: Utils.screenWidth * 0.8,
                                          textColor: UIColor.customNavy,
                                          noOfLines: 1)
        
        return label
    }()
    
    lazy var breakfastTitle: UIStackView = {
        var title = UIStackView()
        if let name = allMeals.breakfast?.name {
            title = createTitleVStack(mealType: "Breakfast",
                                      mealName: name,
                                      action: #selector(showBreakfastDetails))
        }
        
        return title
    }()
    
    lazy var breakfastImage: UIImageView = {
        var imageView = UIImageView()
        if let image = allMeals.breakfast?.image {
            imageView = createImage(imageName: image,
                                action: #selector(showBreakfastDetails))
        }
        
        return imageView
    }()
    
    lazy var breakfastMacro: UIStackView = {
        var macroView = UIStackView()
        
        if let macros = allMeals.breakfast?.macros {
            macroView = createMacroVStack(macros: macros,
                                          action: #selector(showBreakfastDetails))
        }
        
        return macroView
    }()
    
    lazy var refreshBreakfast: UIButton = {
        let button = createRefreshButton(action: #selector(didTapRefreshBreakfast))
        
        return button
    }()
    
    lazy var lunchTitle: UIStackView = {
        var title = UIStackView()
        if let name = allMeals.lunch?.name {
            title = createTitleVStack(mealType: "Lunch",
                                      mealName: name,
                                      action: #selector(showLunchDetails))
        }
        
        return title
    }()
    
    lazy var lunchImage: UIImageView = {
        var imageView = UIImageView()
        if let image = allMeals.lunch?.image {
            imageView = createImage(imageName: image,
                                    action: #selector(showLunchDetails))
        }
        
        return imageView
    }()
    
    lazy var lunchMacro: UIStackView = {
        var macroView = UIStackView()
        
        if let macros = allMeals.lunch?.macros {
            macroView = createMacroVStack(macros: macros,
                                          action: #selector(showLunchDetails))
        }
        
        return macroView
    }()
    
    lazy var refreshLunch: UIButton = {
        let button = createRefreshButton(action: #selector(didTapRefreshLunch))
        
        return button
    }()
    
    lazy var dinnerTitle: UIStackView = {
        let title = UIStackView()
        
        if let name = allMeals.dinner?.name {
            let title = createTitleVStack(mealType: "Dinner",
                                          mealName: name,
                                          action: #selector(showDinnerDetails))
        }
        
        return title
    }()
    
    lazy var dinnerImage: UIImageView = {
        var imageView = UIImageView()
        
        if let image = allMeals.dinner?.image {
            imageView = createImage(imageName: image,
                                    action: #selector(showDinnerDetails))
        }
        
        return imageView
    }()
    
    lazy var dinnerMacro: UIStackView = {
        let macroView = UIStackView()
        
        if let macros = allMeals.dinner?.macros {
            let macroView = createMacroVStack(macros: macros,
                                              action: #selector(showDinnerDetails))
        }
        
        return macroView
    }()
    
    lazy var refreshDinner: UIButton = {
        let button = createRefreshButton(action: #selector(didTapRefreshDinner))
        
        return button
    }()
    
    lazy var proteinShakeTitle: UILabel = {
        let label = UILabel()
        label.text = "Protein Shake"
        label.font = UIFont(name: "KGHAPPYSolid", size: 30)
        label.textColor = UIColor.customOrange
        label.width(Utils.screenWidth * 0.9)
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    lazy var proteinShakeImage: UIImageView = {
        var imageView = UIImageView()
        
        if let image = allMeals.protein?.image {
            imageView = UIImageView(image: UIImage(named: image))
            imageView.contentMode = .scaleAspectFill
        }
        
        return imageView
    }()
    
    lazy var proteinShakeMacro: UIStackView = {
        var macroView = UIStackView()
        
        if let macros = allMeals.protein?.macros {
            macroView = createMacroVStack(macros: macros)
        }
       
        return macroView
    }()
    
    // MARK: - TAP METHODS
    @objc func showBreakfastDetails() {
        if let breakfast = allMeals.breakfast {
            let nextVC = MealDetailsVC(viewModel: .init(mealInfo: breakfast))
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @objc func showLunchDetails() {
        if let lunch = allMeals.lunch {
            let nextVC = MealDetailsVC(viewModel: .init(mealInfo: lunch))
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @objc func showDinnerDetails() {
        if let dinner = allMeals.dinner {
            let nextVC = MealDetailsVC(viewModel: .init(mealInfo: dinner))
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @objc func didTapRefreshBreakfast() {
        print("refresh")
    }
    
    @objc func didTapRefreshLunch() {
        print("refresh")
    }
    
    @objc func didTapRefreshDinner() {
        print("refresh")
    }
    
    // MARK: - FUNCTIONS
    func createRefreshButton(action: Selector) -> UIButton {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.tintColor = UIColor.customOrange
        
        return button
    }
    
    func createMacroHStack(macro: String, value: String) -> UIStackView {
        let macroLabel = UILabel()
        macroLabel.text = macro
        macroLabel.textColor = UIColor.customBlue
        macroLabel.font = UIFont(name: "KGHAPPYSolid", size: 15)
        macroLabel.adjustsFontSizeToFitWidth = true

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = UIColor.customBlue
        valueLabel.font = UIFont(name: "KGHAPPYSolid", size: 15)
        valueLabel.adjustsFontSizeToFitWidth = true
        
        let macroHStack = UIStackView(arrangedSubviews: [macroLabel, valueLabel])
        macroHStack.axis = .horizontal
        
        return macroHStack
    }
    
    func createMacroVStack(macros: MacroBreakdown, action: Selector? = nil) -> UIStackView {
        let cal = createMacroHStack(macro: "Calories", value: "\(macros.calories)g")
        let carbs = createMacroHStack(macro: "Carbs", value: "\(macros.carbs)g")
        let protein = createMacroHStack(macro: "Protein", value: "\(macros.protein)g")
        let fat = createMacroHStack(macro: "Fat", value: "\(macros.fat)")
        
        let macroVStack = Utils.createVStack(subviews: [cal, carbs, protein, fat])
        macroVStack.width(Utils.screenWidth * 0.3)
        macroVStack.spacing = Utils.screenHeight * 0.006
        
        if let action = action {
            addGestureRecognizer(object: macroVStack, action: action)
        }
        
        return macroVStack
    }
    
    func createTitleVStack(mealType: String, mealName: String, action: Selector) -> UIStackView {
        let gridWidth = Utils.screenWidth * 0.9
        
        let label1 = UILabel()
        label1.text = mealType
        label1.font = UIFont(name: "KGHAPPYSolid", size: 30)
        label1.textColor = UIColor.customOrange
        label1.width(gridWidth)
        label1.adjustsFontSizeToFitWidth = true
        
        let label2 = UILabel()
        label2.text = mealName
        label2.font = UIFont(name: "KGHAPPYSolid", size: 20)
        label2.textColor = UIColor.customNavy
        label2.width(gridWidth)
        label2.adjustsFontSizeToFitWidth = true
        
        let labelVStack = Utils.createVStack(subviews: [label1, label2],
                                             spacing: Utils.screenHeight * 0.001)
        
        addGestureRecognizer(object: labelVStack, action: action)
        
        return labelVStack
    }
    
    func addConstraintsForMeal(title: UIView, topToBottomOf: UIView,
                               image: UIView, macro: UIView,
                               refreshButton: UIView? = nil) {
        title.leftToSuperview(offset: Utils.screenWidth * 0.05)
        title.topToBottom(of: topToBottomOf, offset: Utils.screenHeight * 0.03)
        
        image.leftToSuperview(offset: Utils.screenWidth * 0.05)
        image.topToBottom(of: title, offset: Utils.screenHeight * 0.01)
        image.width(Utils.screenWidth * 0.45)
        image.aspectRatio(1.63)
        
        macro.topToBottom(of: title, offset: Utils.screenHeight * 0.01)
        macro.leftToRight(of: image, offset: Utils.screenWidth * 0.02)
        
        if let refreshButton = refreshButton {
            refreshButton.topToBottom(of: title, offset: Utils.screenHeight * 0.05)
            refreshButton.leftToRight(of: macro, offset: Utils.screenWidth * 0.07)
            refreshButton.width(Utils.screenWidth * 0.07)
            refreshButton.aspectRatio(1)
        }
    }
    
    func addGestureRecognizer(object: UIView, action: Selector) {
        let tap = UITapGestureRecognizer(target: self, action: action)
        object.addGestureRecognizer(tap)
    }
    
    func createImage(imageName: String, action: Selector) -> UIImageView {
        let image = UIImageView(image: UIImage(named: imageName))
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        
        addGestureRecognizer(object: image, action: action)
        
        return image
    }
}

extension MealPlanVC {
    
    func setupViews() {
        view.backgroundColor = UIColor(named: "bgColor")
        addSubviews()
        constrainSubviews()
        
        Utils.setNavigationBar(navController: navigationController, navItem: navigationItem)
    }
    
    fileprivate func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(mainTitle)
        
        contentView.addSubview(breakfastTitle)
        contentView.addSubview(breakfastImage)
        contentView.addSubview(breakfastMacro)
        contentView.addSubview(refreshBreakfast)
        
        contentView.addSubview(lunchTitle)
        contentView.addSubview(lunchImage)
        contentView.addSubview(lunchMacro)
        contentView.addSubview(refreshLunch)
        
        contentView.addSubview(dinnerTitle)
        contentView.addSubview(dinnerImage)
        contentView.addSubview(dinnerMacro)
        contentView.addSubview(refreshDinner)

        contentView.addSubview(proteinShakeTitle)
        contentView.addSubview(proteinShakeImage)
        contentView.addSubview(proteinShakeMacro)
    }
    
    fileprivate func constrainSubviews() {
        mainTitle.centerXToSuperview()
        mainTitle.topToSuperview(offset: Utils.screenHeight * 0.04)
        
        addConstraintsForMeal(title: breakfastTitle, topToBottomOf: mainTitle,
                              image: breakfastImage, macro: breakfastMacro,
                              refreshButton: refreshBreakfast)
        
        addConstraintsForMeal(title: lunchTitle, topToBottomOf: breakfastImage,
                              image: lunchImage, macro: lunchMacro,
                              refreshButton: refreshLunch)
        
        addConstraintsForMeal(title: dinnerTitle, topToBottomOf: lunchImage,
                              image: dinnerImage, macro: dinnerMacro,
                              refreshButton: refreshDinner)
        
        addConstraintsForMeal(title: proteinShakeTitle, topToBottomOf: dinnerImage,
                              image: proteinShakeImage, macro: proteinShakeMacro)
    }
}