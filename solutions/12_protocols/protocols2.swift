// protocols2.swift
//
// Protocols can inherit from other protocols and have optional requirements.
// Protocol extensions provide default implementations.
//
// Fix the protocol inheritance and extensions to make the tests pass.

protocol Vehicle {
    var numberOfWheels: Int { get }
    var maxSpeed: Double { get }
}

protocol MotorVehicle: Vehicle {
    var engineSize: Double { get }
    func startEngine() -> String
}

extension Vehicle {
    var description: String {
        return "Vehicle with \(numberOfWheels) wheels, max speed: \(maxSpeed) km/h"
    }
}

extension MotorVehicle {
    func startEngine() -> String {
        return "Vroom! Engine size: \(engineSize)L"
    }
}

struct Bicycle: Vehicle {
    let numberOfWheels = 2
    let maxSpeed = 30.0
}

struct Car: MotorVehicle {
    let numberOfWheels = 4
    let maxSpeed = 200.0
    let engineSize = 2.0
}

struct Motorcycle: MotorVehicle {
    let numberOfWheels = 2
    let maxSpeed = 180.0
    let engineSize = 1.0
}

func race<T: Vehicle>(vehicle: T) -> String {
    return "Racing at \(vehicle.maxSpeed) km/h"
}

func main() {
    let car = Car()
    print("\(car.description), \(car.startEngine())")

    test("Protocol inheritance") {
        let car = Car()
        assertEqual(car.numberOfWheels, 4, "Car has 4 wheels")
        assertEqual(car.engineSize, 2.0, "Car engine size")

        let moto = Motorcycle()
        assertEqual(moto.numberOfWheels, 2, "Motorcycle has 2 wheels")
        assertEqual(moto.maxSpeed, 180.0, "Motorcycle max speed")
        assertEqual(moto.engineSize, 1.0, "Motorcycle engine size")
    }

    test("Protocol extensions") {
        let bike = Bicycle()
        assertEqual(bike.description, "Vehicle with 2 wheels, max speed: 30.0 km/h",
                   "Default description")

        let car = Car()
        assertEqual(car.startEngine(), "Vroom! Engine size: 2.0L",
                   "Default engine start")

        let moto = Motorcycle()
        assertEqual(moto.startEngine(), "Vroom! Engine size: 1.0L",
                   "Uses default implementation")
    }

    test("Generic constraints") {
        let bike = Bicycle()
        assertEqual(race(vehicle: bike), "Racing at 30.0 km/h", "Race bicycle")

        let car = Car()
        assertEqual(race(vehicle: car), "Racing at 200.0 km/h", "Race car")
    }

    runTests()
}
