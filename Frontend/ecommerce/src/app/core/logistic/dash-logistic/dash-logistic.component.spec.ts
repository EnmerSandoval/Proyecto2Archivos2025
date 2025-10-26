import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DashLogisticComponent } from './dash-logistic.component';

describe('DashLogisticComponent', () => {
  let component: DashLogisticComponent;
  let fixture: ComponentFixture<DashLogisticComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DashLogisticComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(DashLogisticComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
