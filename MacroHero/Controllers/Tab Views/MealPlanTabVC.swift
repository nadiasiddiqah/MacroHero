//
//  MealPlanViewController.swift
//  MacroHero
//
//  Created by Nadia Siddiqah on 12/30/21.
//

import UIKit
import Combine
import PKHUD
import AlamofireImage
import Inject

class MealPlanTabVC: UIViewController {
    
    // MARK: - PROPERTIES
    var screenHeight = Utils.screenHeight
    var screenWidth = Utils.screenWidth
    
    var mealPlan = [MealInfo]()
    
    // TODO: Generate in the app before this screen, pass it to this screen
    var breakfastReq = MealReq(type: MealType.breakfast.rawValue,
                               macros: MacroPlan(calories: "100+", carbs: "20+",
                                                 protein: "15+", fat: "10+"),
                               random: true,
                               macroPriority: MacroPriority(macro1: "calories",
                                                            macro2: "protein"))
    var lunchReq = MealReq(type: MealType.lunch.rawValue,
                           macros: MacroPlan(calories: "100+", carbs: "20+",
                                             protein: "15+", fat: "10+"),
                           random: true,
                           macroPriority: MacroPriority(macro1: "calories",
                                                        macro2: "protein"))
    var dinnerReq = MealReq(type: MealType.dinner.rawValue,
                            macros: MacroPlan(calories: "100+", carbs: "20+",
                                              protein: "15+", fat: "10+"),
                            random: true,
                            macroPriority: MacroPriority(macro1: "calories",
                                                         macro2: "protein"))
    
    // MARK: - VIEW METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        fetchMealPlan()
        setupView()
    }
    
    // MARK: - VIEW OBJECTS
    lazy var mainTitle: UILabel = {
        var label = MainLabel()
        label.configure(with: MainLabelModel(
            title: "TODAY'S MEAL PLAN",
            type: .tabView
        ))
        
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(MealCell.self, forCellReuseIdentifier: "mealCell")
        tableView.backgroundColor = .none
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    // MARK: - FETCH DATA
    func fetchMealPlan() {
        MealPlanAPI.fetchMealPlan(mealReqs: AllMealReqs(breakfast: breakfastReq,
                                                        lunch: lunchReq,
                                                        dinner: dinnerReq)) { results in
            self.mealPlan = results
            DispatchQueue.main.async {
                self.tableView.reloadData()
                HUD.hide(animated: true) { _ in
                    HUD.dimsBackground = false
                }
            }
        }
    }
    
    func fetchNewMeal(type: String) {
        HUD.show(.progress)
        HUD.dimsBackground = true

        var req: MealReq?
        var removeAt = 0

        if type == MealType.breakfast.rawValue {
            req = breakfastReq
            removeAt = 0
        } else if type == MealType.lunch.rawValue {
            req = lunchReq
            removeAt = 1
        } else if type == MealType.dinner.rawValue {
            req = dinnerReq
            removeAt = 2
        }

        if let req = req {
            MealPlanAPI.fetchMealBasedOn(req: req) { newMeal in
                if let newMeal = newMeal {
                    self.mealPlan.remove(at: removeAt)
                    self.mealPlan.append(newMeal)

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        HUD.hide(animated: true) { _ in
                            HUD.dimsBackground = false
                        }
                    }
                }
            }
        }
    }
}

extension MealPlanTabVC {
    func setupView() {
        view.backgroundColor = Color.bgColor
        
        // TODO: Investigate why HUD isn't showing 
        HUD.show(.progress)
        HUD.dimsBackground = true
        addSubviews()
        autoLayoutViews()
        constrainSubviews()
    }
    
    func addSubviews() {
        view.addSubview(mainTitle)
        view.addSubview(tableView)
    }
    
    func autoLayoutViews() {
        mainTitle.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func constrainSubviews() {
        NSLayoutConstraint.activate([
            mainTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            tableView.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: screenHeight * 0.03),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension MealPlanTabVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealPlan.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meal = mealPlan[indexPath.row]

        let nextVC = Inject.ViewControllerHost(MealDetailsVC(viewModel: .init(mealInfo: meal)))
        navigationController?.pushViewController(nextVC, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell") as! MealCell

        // sort meal plan data
        mealPlan = mealPlan.sorted { $0.mealOrder < $1.mealOrder }
        let meal = mealPlan[indexPath.row]

        // populate meal plan cells with sorted data
        if let name = meal.name, let type = meal.type, let image = meal.image, let macros = meal.macros {
            cell.nameLabel.text = name
            cell.typeLabel.text = type.capitalized

            if type == "Protein" {
                cell.refreshButton.isHidden = true
            } else {
                cell.refreshButton.isHidden = false
            }

            if let url = URL(string: image), image != "defaultMealImage" {
                let filter = AspectScaledToFillSizeFilter(size: cell.imageIV.frame.size)
                cell.imageIV.af.setImage(withURL: url, filter: filter)
            } else {
                cell.imageIV.image = Image.defaultMealImage
            }

            cell.calLabel.text = macros.calories
            cell.carbLabel.text = "\(macros.carbs)g"
            cell.proteinLabel.text = "\(macros.protein)g"
            cell.fatLabel.text = "\(macros.fat)g"

            cell.buttonAction = {
                print("refresh \(type)")
                self.fetchNewMeal(type: type)
            }
        }

        // update cell UI
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none

        return cell
    }
}