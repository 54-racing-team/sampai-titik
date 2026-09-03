//
//  AlarmManager.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 26/08/26.
//

import Foundation
import AlarmKit
internal import Combine

/// Tanggung jawab: izin, schedule, cancel, dan expose state ke UI.
@MainActor
final class AlarmSchedulerManager: ObservableObject {

    static let shared = AlarmSchedulerManager()

    @Published private(set) var isAuthorized = false
    @Published private(set) var activeAlarmID: UUID?

    private let manager = AlarmManager.shared
    private var updatesTask: Task<Void, Never>?

    private init() {
        observeAlarmUpdates()
    }

    // MARK: - Authorization

    func requestAuthorizationIfNeeded() async {
        switch manager.authorizationState {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            do {
                let status = try await manager.requestAuthorization()
                isAuthorized = (status == .authorized)
            } catch {
                print("Gagal minta izin AlarmKit: \(error)")
                isAuthorized = false
            }
        default:
            isAuthorized = false
        }
    }

    // MARK: - Scheduling

    func scheduleAlarm(after seconds: TimeInterval, label: String, soundTitle: String) async {
        guard isAuthorized else {
            print("Belum diizinkan — panggil requestAuthorizationIfNeeded() dulu")
            return
        }

        let id = UUID()
        let configuration = AlarmConfiguration.makeCountdownConfiguration(
            duration: seconds,
            label: label,
            soundTitle: soundTitle
        )

        do {
            let alarm = try await manager.schedule(id: id, configuration: configuration)
            activeAlarmID = alarm.id
        } catch let error as AlarmManager.AlarmError {
            print("Gagal schedule alarm: \(error)")
        } catch {
            print("Error tak terduga: \(error)")
        }
    }

    func cancelActiveAlarm() {
        AudioManager.shared.stopAlarm()
        guard let id = activeAlarmID else { return }
        try? manager.cancel(id: id)
        activeAlarmID = nil
    }

    func stopActiveAlarm() {
        AudioManager.shared.stopAlarm()
        guard let id = activeAlarmID else { return }
        try? manager.stop(id: id)
        activeAlarmID = nil
    }

    // MARK: - Observing state (buat update UI kalau alarm alerting/paused/dsb)

    private func observeAlarmUpdates() {
        updatesTask = Task {
            for await alarms in manager.alarmUpdates {
                if let current = alarms.first(where: { $0.id == activeAlarmID }) {
                    print("Alarm state berubah: \(current.state)")
                }
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }
}
