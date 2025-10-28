import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LogisticaPageComponent } from './logistica-page.component';

describe('LogisticaPageComponent', () => {
  let component: LogisticaPageComponent;
  let fixture: ComponentFixture<LogisticaPageComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LogisticaPageComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(LogisticaPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
