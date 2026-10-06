import { Injectable, inject, signal } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({ providedIn: 'root' })
export class RealtimeService {
  private api = inject(ApiService);
  readonly status = signal('ngoại tuyến');
  private socket: WebSocket | null = null;
  private timer: number | null = null;

  connect(token: string | null) {
    this.disconnect();
    if (!token) return;
    const socket = new WebSocket(this.api.studySocketUrl(token));
    this.socket = socket;
    socket.onopen = () => {
      this.status.set('trực tiếp');
      this.timer = window.setInterval(() => {
        if (socket.readyState === WebSocket.OPEN) socket.send(JSON.stringify({ seconds: 15 }));
      }, 15000);
    };
    socket.onclose = () => this.status.set('ngoại tuyến');
    socket.onerror = () => this.status.set('ngoại tuyến');
  }

  disconnect() {
    if (this.timer != null) window.clearInterval(this.timer);
    this.timer = null;
    this.socket?.close();
    this.socket = null;
    this.status.set('ngoại tuyến');
  }
}
