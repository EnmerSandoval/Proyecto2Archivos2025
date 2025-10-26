import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DashModComponent } from './dash-mod.component';

describe('DashModComponent', () => {
  let component: DashModComponent;
  let fixture: ComponentFixture<DashModComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DashModComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(DashModComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
