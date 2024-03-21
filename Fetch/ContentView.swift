import SwiftUI
import Combine

struct Recipe: Codable, Identifiable {
    let id: String
    let name: String
    let thumbnail: URL
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case thumbnail = "strMealThumb"
    }
}

struct RecipeDetails: Codable {
    let id: String
    let name: String
    let instructions: String
    let ingredients: [String]
    let measures: [String]

    var strIngredient1: String?
    var strIngredient2: String?
    var strIngredient3: String?
    var strIngredient4: String?
    var strIngredient5: String?
    var strIngredient6: String?
    var strIngredient7: String?
    var strIngredient8: String?
    var strIngredient9: String?
    var strIngredient10: String?
    var strIngredient11: String?
    var strIngredient12: String?
    var strIngredient13: String?
    var strIngredient14: String?
    var strIngredient15: String?
    var strIngredient16: String?
    var strIngredient17: String?
    var strIngredient18: String?
    var strIngredient19: String?
    var strIngredient20: String?
    
    var strMeasure1: String?
    var strMeasure2: String?
    var strMeasure3: String?
    var strMeasure4: String?
    var strMeasure5: String?
    var strMeasure6: String?
    var strMeasure7: String?
    var strMeasure8: String?
    var strMeasure9: String?
    var strMeasure10: String?
    var strMeasure11: String?
    var strMeasure12: String?
    var strMeasure13: String?
    var strMeasure14: String?
    var strMeasure15: String?
    var strMeasure16: String?
    var strMeasure17: String?
    var strMeasure18: String?
    var strMeasure19: String?
    var strMeasure20: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case instructions = "strInstructions"
        case strDrinkAlternate, strCategory, strArea, strMealThumb
        
        case ingredient1 = "strIngredient1"
        case ingredient2 = "strIngredient2"
        case ingredient3 = "strIngredient3"
        case ingredient4 = "strIngredient4"
        case ingredient5 = "strIngredient5"
        case ingredient6 = "strIngredient6"
        case ingredient7 = "strIngredient7"
        case ingredient8 = "strIngredient8"
        case ingredient9 = "strIngredient9"
        case ingredient10 = "strIngredient10"
        case ingredient11 = "strIngredient11"
        case ingredient12 = "strIngredient12"
        case ingredient13 = "strIngredient13"
        case ingredient14 = "strIngredient14"
        case ingredient15 = "strIngredient15"
        case ingredient16 = "strIngredient16"
        case ingredient17 = "strIngredient17"
        case ingredient18 = "strIngredient18"
        case ingredient19 = "strIngredient19"
        case ingredient20 = "strIngredient20"
        
        case measurement1 = "strMeasure1"
        case measurement2 = "strMeasure2"
        case measurement3 = "strMeasure3"
        case measurement4 = "strMeasure4"
        case measurement5 = "strMeasure5"
        case measurement6 = "strMeasure6"
        case measurement7 = "strMeasure7"
        case measurement8 = "strMeasure8"
        case measurement9 = "strMeasure9"
        case measurement10 = "strMeasure10"
        case measurement11 = "strMeasure11"
        case measurement12 = "strMeasure12"
        case measurement13 = "strMeasure13"
        case measurement14 = "strMeasure14"
        case measurement15 = "strMeasure15"
        case measurement16 = "strMeasure16"
        case measurement17 = "strMeasure17"
        case measurement18 = "strMeasure18"
        case measurement19 = "strMeasure19"
        case measurement20 = "strMeasure20"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.instructions = try container.decode(String.self, forKey: .instructions)
        
        var ingredients: [String] = []
        var measures: [String] = []
        
        for index in 1...20 {
            let ingredientKey = "strIngredient\(index)"
            let measureKey = "strMeasure\(index)"
            
            if let ingredientCodingKey = CodingKeys(rawValue: ingredientKey),
               let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientCodingKey) {
                ingredients.append(ingredient)
            }
            
            if let measureCodingKey = CodingKeys(rawValue: measureKey),
               let measure = try container.decodeIfPresent(String.self, forKey: measureCodingKey) {
                measures.append(measure)
            }
        }
        
        self.ingredients = ingredients
        self.measures = measures
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(instructions, forKey: .instructions)
    }
}

class ViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var recipeDetails: RecipeDetails?
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchRecipes()
    }
    
    func fetchRecipes() {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: RecipeResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Recipes fetch completion: \(completion)")
            } receiveValue: { [weak self] response in
                self?.recipes = response.meals.sorted { $0.name < $1.name }
            }
            .store(in: &cancellables)
    }
     
    func fetchRecipeDetails(for id: String) {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else {
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Recipe details fetch completion: \(completion)")
            } receiveValue: { [weak self] data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw data received: \(jsonString)")
                } else {
                    print("Raw data could not be converted to string")
                }
                do {
                    
                    let response = try JSONDecoder().decode(RecipeDetailsResponse.self,from: data)
                    guard let details = response.meals.first else {
                        print("No details found")
                        return
                    }
                    DispatchQueue.main.async {
                        self?.recipeDetails = details
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
            .store(in: &cancellables)
    }
}

struct RecipeResponse: Codable {
    let meals: [Recipe]
}

struct RecipeDetailsResponse: Codable {
    let meals: [RecipeDetails]
}

struct RecipeListView: View {
    @ObservedObject private var viewModel = ViewModel()
    
    var filteredRecipes: [Recipe] {
        if viewModel.searchText.isEmpty {
            return viewModel.recipes
        } else {
            return viewModel.recipes.filter {
                $0.name.localizedCaseInsensitiveContains(viewModel.searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailsView(recipeId: recipe.id)) {
                                HStack {
                                    AsyncImage(url: recipe.thumbnail) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    
                                    Text(recipe.name)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Dessert Recipes")
            }
        }
    }
}

struct RecipeDetailsView: View {
    @StateObject private var viewModel = ViewModel()
    let recipeId: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let details = viewModel.recipeDetails {
                    Text(details.name)
                        .font(.title)
                    
                    Text(details.instructions)
                        .padding(.top)
                    
                    Text("Ingredients")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(0..<details.ingredients.count, id: \.self) { index in
                        Text("- \(details.ingredients[index])" + (index < details.measures.count ? ": \(details.measures[index])" : ""))
                    }
                } else {
                    ProgressView()
                        .onAppear {
                            viewModel.fetchRecipeDetails(for: recipeId)
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
    }
}

struct ContentView: View {
    var body: some View {
        RecipeListView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .foregroundColor(.primary)
            
            Button(action: {
                text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .opacity(text.isEmpty ? 0 : 1)
            }
            .padding(.trailing, 10)
        }
    }
}
