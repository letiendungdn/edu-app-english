import { Injectable, signal } from '@angular/core';

/** Nhịp "đang học" qua WebSocket. Chỉ gửi khi tab đang hiển thị, để lúc bỏ máy đi chỗ khác không bị tính giờ học. */
@Injectable({ providedIn: 'root' })
export class RealtimeService {
  readonly status = signal('ngoại tuyến');
  private socket: WebSocket | null = null;
  private timer: number | null = null;

  connect(token: string | null) {
    this.disconnect();
    if (!token) return;
    const origin = window.location.origin.replace(/^http/, 'ws');
    const socket = new WebSocket(`${origin}/ws/study`);
    this.socket = socket;
    socket.onopen = () => {
      // Token gửi trong tin đầu tiên, không đặt trên URL vì URL bị ghi vào access log.
      socket.send(JSON.stringify({ type: 'auth', token }));
    };
    socket.onmessage = (event) => {
      if (String(event.data).includes('authenticated')) {
        this.status.set('trực tiếp');
        this.timer = window.setInterval(() => {
          if (socket.readyState === WebSocket.OPEN && document.visibilityState === 'visible') {
            socket.send(JSON.stringify({ seconds: 15 }));
          }
        }, 15000);
      }
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
