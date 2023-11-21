/*
 * Copyright (C) 2015 The Gravitee team (http://gravitee.io)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { Component, forwardRef, Input } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

@Component({
  selector: 'api-documentation-visibility',
  template: require('./api-documentation-v4-visibility.component.html'),
  styles: [require('./api-documentation-v4-visibility.component.scss')],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => ApiDocumentationV4VisibilityComponent),
      multi: true,
    },
  ],
})
export class ApiDocumentationV4VisibilityComponent implements ControlValueAccessor {
  @Input()
  public showSubtitle: boolean;

  @Input()
  public documentationType: 'page' | 'folder' = 'page';

  _value: string;
  protected _onChange: (_selection: 'PUBLIC' | 'PRIVATE') => void = () => ({});

  protected _onTouched: () => void = () => ({});

  // From ControlValueAccessor interface
  public registerOnChange(fn: (selection: 'PUBLIC' | 'PRIVATE') => void): void {
    this._onChange = fn;
  }

  // From ControlValueAccessor interface
  public registerOnTouched(fn: () => void): void {
    this._onTouched = fn;
  }

  writeValue(selection: 'PUBLIC' | 'PRIVATE'): void {
    this._value = selection;
  }
}
