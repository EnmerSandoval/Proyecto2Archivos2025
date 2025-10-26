import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DashComunComponent } from './dash-comun.component';

describe('DashComunComponent', () => {
  let component: DashComunComponent;
  let fixture: ComponentFixture<DashComunComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DashComunComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(DashComunComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
