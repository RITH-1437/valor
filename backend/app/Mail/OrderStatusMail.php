<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class OrderStatusMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public string $name,
        public string $orderNumber,
        public string $status,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(subject: "VALOR Order #{$this->orderNumber} - " . ucfirst($this->status));
    }

    public function content(): Content
    {
        $statusColor = match($this->status) {
            'confirmed' => '#3B82F6',
            'processing' => '#06B6D4',
            'shipped' => '#D4AF37',
            'delivered' => '#10B981',
            'cancelled' => '#EF4444',
            default => '#6B7280',
        };

        return new Content(
            htmlString: <<<HTML
            <!DOCTYPE html>
            <html>
            <head><meta charset="utf-8"></head>
            <body style="margin:0;padding:0;background-color:#111111;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
            <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#111111;padding:40px 20px;">
            <tr><td align="center">
            <table width="600" cellpadding="0" cellspacing="0" style="background-color:#1F2937;border-radius:16px;overflow:hidden;">
            <tr><td style="background-color:#111111;padding:30px 40px;text-align:center;">
            <h1 style="color:#D4AF37;font-size:28px;font-weight:800;letter-spacing:4px;margin:0;">VALOR</h1>
            </td></tr>
            <tr><td style="padding:40px;">
            <h2 style="color:#FFFFFF;font-size:22px;font-weight:700;margin:0 0 20px 0;">Order Update</h2>
            <p style="color:#6B7280;font-size:14px;line-height:1.6;">Hi {$this->name},</p>
            <p style="color:#6B7280;font-size:14px;line-height:1.6;">Your order <strong style="color:#FFFFFF;">#{$this->orderNumber}</strong> status has been updated.</p>
            <div style="background-color:#111111;border-radius:12px;padding:20px;margin:20px 0;text-align:center;">
            <p style="color:#6B7280;font-size:12px;margin:0 0 8px 0;text-transform:uppercase;letter-spacing:2px;">Current Status</p>
            <p style="color:{$statusColor};font-size:24px;font-weight:800;margin:0;text-transform:uppercase;">{$this->status}</p>
            </div>
            <p style="color:#6B7280;font-size:14px;line-height:1.6;">Thank you for shopping with VALOR.</p>
            </td></tr>
            <tr><td style="background-color:#111111;padding:24px 40px;text-align:center;">
            <p style="color:#6B7280;font-size:12px;margin:0;">© 2026 VALOR. All rights reserved.</p>
            </td></tr>
            </table>
            </td></tr></table>
            </body></html>
            HTML
        );
    }
}
