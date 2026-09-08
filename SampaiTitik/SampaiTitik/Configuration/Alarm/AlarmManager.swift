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
            LiveActivityManager.shared.endActivity()
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
            LiveActivityManager.shared.endActivity()
        } catch {
            print("Error tak terduga: \(error)")
            LiveActivityManager.shared.endActivity()
        }
    }

    func cancelActiveAlarm() {
        AudioManager.shared.stopAlarm()
        if let id = activeAlarmID {
            try? manager.cancel(id: id)
            activeAlarmID = nil
        }
        LiveActivityManager.shared.endActivity()
    }

    func stopActiveAlarm() {
        AudioManager.shared.stopAlarm()
        if let id = activeAlarmID {
            try? manager.stop(id: id)
            activeAlarmID = nil
        }
        LiveActivityManager.shared.endActivity()
    }

    // MARK: - Observing state (buat update UI kalau alarm alerting/paused/dsb)

    private func observeAlarmUpdates() {
        updatesTask = Task {
            for await alarms in manager.alarmUpdates {
                guard let activeID = activeAlarmID else { continue }
                
                if let current = alarms.first(where: { $0.id == activeID }) {
                    print("Alarm state berubah: \(current.state)")
                } else {
                    // Alarm sudah tidak ada di daftar alarms -> alarm telah dimatikan / di-dismiss oleh user
                    print("Alarm telah dimatikan / selesai oleh user")
                    activeAlarmID = nil
                    LiveActivityManager.shared.endActivity()
                    AudioManager.shared.stopAlarm()
                }
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }
}
