import {HttpClient, HttpEvent} from '@angular/common/http';
import {Injectable} from '@angular/core';
import {Observable, of} from 'rxjs';
import {catchError} from 'rxjs/operators';

import { environment } from '../environments/environment';
import {LoggingMessage, MessageService} from 'src/app/message.service';

@Injectable({
    providedIn: 'root'
})

export class JerooService {
    serverLink: string;

    constructor(
        private httpClient: HttpClient,
        private messageService: MessageService,
    ) {
        this.serverLink = environment.serverLink || '/service';
    }

    public upload(formData: any): Observable<HttpEvent<string>> {
        return this.httpClient.post(`${this.serverLink}/upload`, formData, {
            reportProgress: true,
            observe: 'events',
            responseType: 'text'
        }).pipe(
            catchError(this.handleError<HttpEvent<string>>('upload'))
        );
    }

    public list(filterExt: string): Observable<string[]> {
        return this.httpClient.get<string[]>(
          `${this.serverLink}/list`,
          {params: {filter: filterExt}}
          ).pipe(
            catchError(this.handleError<string[]>('list', []))
        );
    }

    public load(fileName: string): Observable<string | null> {
        return this.httpClient.get(`${this.serverLink}/files/${fileName}`, {responseType: 'text'})
          .pipe(catchError(this.handleError('load file', null)));
    }

    /**
     * Handle Http operation that failed.
     * Let the app continue.
     * @param operation - name of the operation that failed
     * @param result - optional value to return as the observable result
     */
    private handleError<T>(operation = 'operation', result?: T) {
        return (error: any): Observable<T> => {
            // TODO: send the error to remote logging infrastructure
            console.error(error); // log to console instead
            // TODO: better job of transforming error for user consumption
            this.log(`${operation} failed: ${error.message}`);
            // Let the app keep running by returning an empty result.
            return of(result as T);
        };
    }

    /** Log a HeroService message with the MessageService */
    private log(message: string) {
        this.messageService.addMessage(new LoggingMessage(`JerooService: ${message}`));
    }
}
