import SwiftUI
import HealthKit
struct DashboardView: View {
    @State private var steps: Int = 0
    @State private var calories: Double = 0
    @State private var distance: Double = 0
    @State private var activeEnergy: Double = 0
    @State private var showingWorkoutSheet = false
    @State private var goalProgress: Double = 0.65
    private let healthStore = HKHealthStore()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.3)
                            .foregroundColor(.blue)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(self.goalProgress, 1.0)))
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.blue)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear, value: goalProgress)
                        VStack {
                            Text("\(Int(goalProgress * 100))%")
                                .font(.system(size: 40, weight: .bold))
                            Text("Дневная цель")
                                .font(.headline)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                    HStack(spacing: 15) {
                        ActivityCard(title: "Шаги", value: "\(steps)", icon: "figure.walk")
                        ActivityCard(title: "Калории", value: "\(Int(calories)) ккал", icon: "flame.fill")
                    }
                    HStack(spacing: 15) {
                        ActivityCard(title: "Дистанция", value: String(format: "%.2f км", distance), icon: "map")
                        ActivityCard(title: "Активность", value: "\(Int(activeEnergy)) ккал", icon: "bolt.fill")
                    }
                    Button(action: {
                        showingWorkoutSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Добавить тренировку")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showingWorkoutSheet) {
                        WorkoutSelectionView()
                    }
                    VStack(alignment: .leading) {
                        Text("Последние тренировки")
                            .font(.headline)
                            .padding(.horizontal)
                        ForEach(1...3, id: \.self) { i in
                            WorkoutListItem(
                                type: i == 1 ? "Бег" : (i == 2 ? "Силовая" : "Йога"),
                                duration: i == 1 ? "30 мин" : (i == 2 ? "45 мин" : "20 мин"),
                                date: "Сегодня"
                            )
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Фитнес-трекер")
            .onAppear {
                requestAuthorization()
                loadHealthData()
            }
        }
    }
    func requestAuthorization() {
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                print("Разрешение HealthKit получено")
            } else if let error = error {
                print("Ошибка авторизации HealthKit: \(error.localizedDescription)")
            }
        }
    }
    func loadHealthData() {
        steps = 8456
        calories = 320.5
        distance = 5.2
        activeEnergy = 450.8
    }
}
struct ActivityCard: View {
    var title: String
    var value: String
    var icon: String
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
struct WorkoutListItem: View {
    var type: String
    var duration: String
    var date: String
    var body: some View {
        HStack {
            Image(systemName: type == "Бег" ? "figure.run" : (type == "Силовая" ? "dumbbell.fill" : "figure.mind.and.body"))
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 40)
            VStack(alignment: .leading) {
                Text(type)
                    .font(.headline)
                Text(duration)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
struct WorkoutSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    let workoutTypes = ["Бег", "Ходьба", "Велосипед", "Силовая", "Плавание", "Йога", "HIIT"]
    var body: some View {
        NavigationView {
            List {
                ForEach(workoutTypes, id: \.self) { workout in
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(workout)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Выберите тип тренировки")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}