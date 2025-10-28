import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ModeracionPageComponent } from './moderacion-page.component';

describe('ModeracionPageComponent', () => {
  let component: ModeracionPageComponent;
  let fixture: ComponentFixture<ModeracionPageComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ModeracionPageComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ModeracionPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
