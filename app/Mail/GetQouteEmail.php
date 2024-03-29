<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class GetQouteEmail extends Mailable
{
    use Queueable, SerializesModels;

    public $data;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct( $data)
    {
        $this->data = $data;
    }

    /**
     * Get the message envelope.
     *
     * @return \Illuminate\Mail\Mailables\Envelope
     */
    // public function envelope()
    // {
    //     return new Envelope(
    //         subject: 'Get Qoute Email',
    //     );
    // }

    /**
     * Get the message content definition.
     *
     * @return \Illuminate\Mail\Mailables\Content
     */
    // public function content()
    // {
    //     return new Content(
    //         view: 'view.name',
    //     );
    // }

    /**
     * Get the attachments for the message.
     *
     * @return array
     */
    public function attachments()
    {
        return [];
    }

    public function build()
    {
        $address    = env('MAIL_FROM_ADDRESS');
        $subject    = $this->data['subject'];
        $name       = env('MAIL_FROM_NAME');
        $body       = $this->data['body'];
        $reqData    = $this->data['reqData'];
        $filename   = $this->data['filename'];
        
        return $this->from($address, $name)
                    ->to($this->data['to'])
                    ->attach(storage_path('app/public/'.$filename))
                    ->view('emails.getqoute')
                    ->replyTo($address, $name)
                    ->subject($subject)
                    ->with(['body'=>$body, 'reqData'=>$reqData]);
        
        
    }
}
