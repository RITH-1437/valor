<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class WelcomeMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public string $name,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(subject: 'Welcome to VALOR');
    }

    public function content(): Content
    {
        return new Content(
            htmlString: $this->buildHtml('Welcome to VALOR', "Hi {$this->name},\n\nThank you for joining VALOR. We're excited to have you as part of our community.\n\nExplore our curated collection of premium men's fashion.\n\nBest regards,\nThe VALOR Team"),
        );
    }

    private function buildHtml(string $title, string $body): string
    {
        $paragraphs = explode("\n\n", $body);
        $htmlBody = '';
        foreach ($paragraphs as $p) {
            $htmlBody .= '<p style="color:#6B7280;font-size:14px;line-height:1.6;margin:0 0 16px 0;">' . nl2br(e($p)) . '</p>';
        }

        return $this->baseTemplate($title, $htmlBody);
    }

    protected function baseTemplate(string $title, string $content): string
    {
        return <<<HTML
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
        <h2 style="color:#FFFFFF;font-size:22px;font-weight:700;margin:0 0 20px 0;">{$title}</h2>
        {$content}
        </td></tr>
        <tr><td style="background-color:#111111;padding:24px 40px;text-align:center;">
        <p style="color:#6B7280;font-size:12px;margin:0;">© 2026 VALOR. All rights reserved.</p>
        <p style="color:#6B7280;font-size:12px;margin:8px 0 0 0;">Premium Men's Fashion</p>
        </td></tr>
        </table>
        </td></tr></table>
        </body></html>
        HTML;
    }
}
