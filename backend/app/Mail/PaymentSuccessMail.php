<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class PaymentSuccessMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public string $name,
        public string $orderNumber,
        public float $amount,
        public string $status,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(subject: "VALOR Payment {$this->status} - Order #{$this->orderNumber}");
    }

    public function content(): Content
    {
        $statusColor = $this->status === 'paid' ? '#10B981' : '#EF4444';
        $statusText = $this->status === 'paid' ? 'Payment Successful' : 'Payment Failed';

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
            <div style="text-align:center;margin-bottom:24px;">
            <div style="width:60px;height:60px;border-radius:50%;background-color:{$statusColor}20;display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;">
            <span style="font-size:28px;">{$this->status === 'paid' ? '✓' : '✗'}</span>
            </div>
            <h2 style="color:{$statusColor};font-size:20px;font-weight:700;margin:0;">{$statusText}</h2>
            </div>
            <p style="color:#6B7280;font-size:14px;line-height:1.6;">Hi {$this->name},</p>
            <div style="background-color:#111111;border-radius:12px;padding:20px;margin:20px 0;">
            <table width="100%" cellpadding="0" cellspacing="0">
            <tr><td style="color:#6B7280;font-size:13px;padding:8px 0;">Order Number</td><td style="color:#FFFFFF;font-size:13px;font-weight:600;text-align:right;padding:8px 0;">#{$this->orderNumber}</td></tr>
            <tr><td style="color:#6B7280;font-size:13px;padding:8px 0;border-top:1px solid #374151;">Amount</td><td style="color:#D4AF37;font-size:16px;font-weight:700;text-align:right;padding:8px 0;border-top:1px solid #374151;">\${number_format($this->amount, 2)}</td></tr>
            <tr><td style="color:#6B7280;font-size:13px;padding:8px 0;border-top:1px solid #374151;">Status</td><td style="color:{$statusColor};font-size:13px;font-weight:600;text-align:right;padding:8px 0;border-top:1px solid #374151;">{$this->status}</td></tr>
            </table>
            </div>
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
